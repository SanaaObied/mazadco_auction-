from flask import Flask, request, jsonify
import joblib
import numpy as np
import pandas as pd
from sklearn.tree import DecisionTreeClassifier
import threading
import logging

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
        
        # Ensure all required fields are present in the data
        features = pd.DataFrame([{
            'account_authenticity': data.get('account_authenticity', 0),
            'bidding_score': data.get('bidding_score', 0),
            'transaction_score': data.get('transaction_score', 0),
            'delivery_score': data.get('delivery_score', 0),
            'fraud_reports': data.get('fraud_reports', 0)
        }])
        
        # Perform prediction
        prediction = model.predict(features)[0]
        risk_map = {0: 'Low', 1: 'Medium', 2: 'High'}
        result = risk_map.get(prediction, 'Unknown')
        
        # Log the received data and the result
        logger.info(f"Received data: {data}")
        logger.info(f"Prediction result: {result}")
        
        # Append the data to a CSV file
        new_row = pd.DataFrame([{
            'account_authenticity': data.get('account_authenticity', 0),
            'bidding_score': data.get('bidding_score', 0),
            'transaction_score': data.get('transaction_score', 0),
            'delivery_score': data.get('delivery_score', 0),
            'fraud_reports': data.get('fraud_reports', 0),
            'risk_level': result
        }])
        
        with lock:
            # Append the data to CSV, ensuring headers are written only once
            new_row.to_csv('data/user_behavior.csv', mode='a', index=False, header=False)
        
        return jsonify({'risk_level': result})
    
    except Exception as e:
        logger.error(f"Error in prediction: {str(e)}")
        return jsonify({'error': 'Failed to process prediction'}), 500


@app.route('/retrain', methods=['POST'])
def retrain():
    global model
    try:
        with lock:
            # Load the CSV data
            df = pd.read_csv('data/user_behavior.csv')
            
            # Check if CSV has the required columns
            required_columns = ['account_authenticity', 'bidding_score', 'transaction_score',
                                'delivery_score', 'fraud_reports', 'risk_level']
            if not all(col in df.columns for col in required_columns):
                return jsonify({'error': 'Missing required columns in the dataset'}), 400
            
            # Prepare data for retraining
            X = df[['account_authenticity', 'bidding_score', 'transaction_score', 'delivery_score',
                    'fraud_reports']]
            y = df['risk_level'].map({'Low': 0, 'Medium': 1, 'High': 2})
            
            # Retrain the model
            model = DecisionTreeClassifier()
            model.fit(X, y)
            
            # Save the trained model
            joblib.dump(model, model_path)
        
        return jsonify({'message': '✅ Model retrained successfully.'})
    
    except Exception as e:
        logger.error(f"Error during retraining: {str(e)}")
        return jsonify({'error': f"Failed to retrain the model: {str(e)}"}), 500


if __name__ == '__main__':
    app.run(debug=True, use_reloader=False)




