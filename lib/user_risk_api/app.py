from flask import Flask, request, jsonify
import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
import threading
import logging
import os
import mysql.connector  # الاتصال بقاعدة البيانات

app = Flask(__name__)

model_path = 'model/risk_model.pkl'

# Initialize logger
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load model
model = joblib.load(model_path)
logger.info("Model loaded successfully.")

# Thread lock for safe reading and writing
lock = threading.Lock()

@app.route('/predict-risk', methods=['GET', 'POST'])
def predict_risk():
    logger.info("Received prediction request.")
    try:
        data = request.get_json()

        features = pd.DataFrame([{
            'account_authenticity': data.get('account_authenticity', 0),
            'bidding_score': data.get('bidding_score', 0),
            'transaction_score': data.get('transaction_score', 0),
            'delivery_score': data.get('delivery_score', 0),
            'fraud_reports': data.get('fraud_reports', 0)
        }])

        prediction = model.predict(features)[0]
        risk_map = {0: 'Low', 1: 'Medium', 2: 'High'}
        result = risk_map.get(prediction, 'Unknown')

        logger.info(f"Received data: {data}")
        logger.info(f"Prediction result: {result}")

        new_row = pd.DataFrame([{
            'account_authenticity': data.get('account_authenticity', 0),
            'bidding_score': data.get('bidding_score', 0),
            'transaction_score': data.get('transaction_score', 0),
            'delivery_score': data.get('delivery_score', 0),
            'fraud_reports': data.get('fraud_reports', 0),
            'risk_level': result
        }])

        file_path = 'data/user_behavior.csv'

        with lock:
            try:
                existing_df = pd.read_csv(file_path)
                duplicate = ((existing_df == new_row.iloc[0]).all(axis=1)).any()
            except FileNotFoundError:
                duplicate = False

            if not duplicate:
                new_row.to_csv(file_path, mode='a', index=False, header=not os.path.exists(file_path))
                logger.info("New data appended to the CSV file.")
            else:
                logger.info("Duplicate data detected. Skipping write operation.")

        return jsonify({'risk_level': result})

    except Exception as e:
        logger.error(f"Error in prediction: {str(e)}")
        return jsonify({'error': 'Failed to process prediction'}), 500


@app.route('/retrain', methods=['POST'])
def retrain():
    global model
    try:
        with lock:
            # الاتصال بقاعدة البيانات
            conn = mysql.connector.connect(
                host='localhost',
                user='root',
                password='',
                database='final'
            )
            cursor = conn.cursor(dictionary=True)

            # جلب البيانات من الجدول
            cursor.execute("""
                SELECT account_authenticity, bidding_score, transaction_score,
                    delivery_score, fraud_reports, risk_level
                FROM dataset_new
            """)
            rows = cursor.fetchall()

            if not rows:
                return jsonify({'error': 'لا توجد بيانات متاحة في قاعدة البيانات'}), 400

            df = pd.DataFrame(rows)

            required_columns = ['account_authenticity', 'bidding_score', 'transaction_score',
                                'delivery_score', 'fraud_reports', 'risk_level']
            if not all(col in df.columns for col in required_columns):
                return jsonify({'error': 'Missing required columns in the database table'}), 400

            X = df[['account_authenticity', 'bidding_score', 'transaction_score', 'delivery_score', 'fraud_reports']]
            y = df['risk_level'].map({'Low': 0, 'Medium': 1, 'High': 2})

            model = RandomForestClassifier(n_estimators=100, random_state=42)
            model.fit(X, y)

            joblib.dump(model, model_path)

            cursor.close()
            conn.close()

            return jsonify({'message': '✅ Model retrained successfully using data from database.'})

    except Exception as e:
        logger.error(f"Error during retraining: {str(e)}")
        return jsonify({'error': f"Failed to retrain the model: {str(e)}"}), 500


if __name__ == '__main__':
    app.run(debug=True, use_reloader=False)
