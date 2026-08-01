from flask import Flask, request, jsonify
import joblib
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
import threading
import logging
import mysql.connector
import traceback  # لإظهار الخطأ كاملًا

app = Flask(__name__)

model_path = 'model/risk_model.pkl'

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

try:
    model = joblib.load(model_path)
    logger.info("Model loaded successfully.")
except Exception as e:
    logger.error("Failed to load model", exc_info=True)
    model = None

lock = threading.Lock()

@app.route('/predict-risk', methods=['POST'])
def predict_risk():
    logger.info("Received prediction request.")
    try:
        data = request.get_json()
        logger.info(f"Input data: {data}")

        input_row = {
            'account_authenticity': data.get('account_authenticity', 0),
            'bidding_score': data.get('bidding_score', 0),
            'transaction_score': data.get('transaction_score', 0),
            'fraud_reports': data.get('fraud_reports', 0)
        }

        features = pd.DataFrame([input_row])
        logger.info(f"Constructed features DataFrame:\n{features}")

        if model is None:
            logger.error("Model is not loaded.")
            return jsonify({'error': 'Model is not loaded'}), 500

        try:
            prediction = model.predict(features)[0]
        except Exception as e:
            logger.exception("Prediction failed")
            return jsonify({'error': f'Prediction failed: {str(e)}'}), 500

        risk_map = {0: 'Low', 1: 'Medium', 2: 'High'}
        result = risk_map.get(prediction, 'Unknown')

        logger.info(f"Prediction result: {result}")

        input_row['risk_level'] = result

        with lock:
            conn = mysql.connector.connect(
                host='localhost',
                user='root',
                password='',
                database='final'
            )
            cursor = conn.cursor()

            check_query = """
                SELECT COUNT(*) FROM dataset_new
                WHERE account_authenticity = %s AND bidding_score = %s AND
                      transaction_score = %s AND fraud_reports = %s
            """
            cursor.execute(check_query, (
                input_row['account_authenticity'],
                input_row['bidding_score'],
                input_row['transaction_score'],
                input_row['fraud_reports']
            ))
            (count,) = cursor.fetchone()

            if count == 0:
                insert_query = """
                    INSERT INTO dataset_new (
                        account_authenticity, bidding_score, transaction_score,
                        fraud_reports, risk_level
                    )
                    VALUES (%s, %s, %s, %s, %s)
                """
                cursor.execute(insert_query, (
                    input_row['account_authenticity'],
                    input_row['bidding_score'],
                    input_row['transaction_score'],
                    input_row['fraud_reports'],
                    input_row['risk_level']
                ))
                conn.commit()
                logger.info("New data inserted into database.")
            else:
                logger.info("Duplicate data detected. Skipping insert.")

            cursor.close()
            conn.close()

        return jsonify({'risk_level': result})

    except Exception as e:
        logger.error("Unhandled exception in /predict-risk endpoint")
        traceback_str = traceback.format_exc()
        logger.error(traceback_str)
        return jsonify({'error': 'Failed to process prediction', 'details': str(e), 'trace': traceback_str}), 500


@app.route('/retrain', methods=['POST'])
def retrain():
    global model
    try:
        with lock:
            conn = mysql.connector.connect(
                host='localhost',
                user='root',
                password='',
                database='final'
            )
            cursor = conn.cursor(dictionary=True)

            cursor.execute("""
                SELECT account_authenticity, bidding_score, transaction_score,
                       fraud_reports, risk_level
                FROM dataset_new
            """)
            rows = cursor.fetchall()

            if not rows:
                return jsonify({'error': 'No data available in database'}), 400

            df = pd.DataFrame(rows)

            required_columns = ['account_authenticity', 'bidding_score', 'transaction_score',
                                'fraud_reports', 'risk_level']
            if not all(col in df.columns for col in required_columns):
                return jsonify({'error': 'Missing required columns in database table'}), 400

            X = df[['account_authenticity', 'bidding_score', 'transaction_score',
                    'fraud_reports']]
            y = df['risk_level'].map({'Low': 0, 'Medium': 1, 'High': 2})

            model = RandomForestClassifier(n_estimators=100, random_state=42)
            model.fit(X, y)

            joblib.dump(model, model_path)

            cursor.close()
            conn.close()

            logger.info("Model retrained and saved successfully.")
            return jsonify({'message': 'Model retrained successfully using data from database.'})

    except Exception as e:
        logger.exception("Retraining failed")
        return jsonify({'error': f"Failed to retrain the model: {str(e)}"}), 500


if __name__ == '__main__':
    app.run(debug=True, use_reloader=False)
