import pandas as pd
from sklearn.tree import DecisionTreeClassifier
import joblib
import os


df = pd.read_csv('data/user_behavior.csv')

X = df[['account_authenticity', 'bidding_score', 'transaction_score', 'delivery_score', 'fraud_reports']]
y = df['risk_level'].map({'Low': 0, 'Medium': 1, 'High': 2})

model = DecisionTreeClassifier()
model.fit(X, y)

os.makedirs('model', exist_ok=True)
joblib.dump(model, 'model/risk_model.pkl')

print("✅ Model trained and saved successfully.")
