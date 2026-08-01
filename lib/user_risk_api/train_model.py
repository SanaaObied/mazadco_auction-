import pandas as pd
from sklearn.ensemble import RandomForestClassifier
import joblib
import os

# تحميل البيانات
df = pd.read_csv('data/balanced_user_behavior_new.csv')

# تحديد الميزات بدون delivery_score
X = df[['account_authenticity', 'bidding_score', 'transaction_score', 'fraud_reports']]
y = df['risk_level'].map({'Low': 0, 'Medium': 1, 'High': 2})

# تدريب النموذج باستخدام Random Forest
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X, y)

# حفظ النموذج
os.makedirs('model', exist_ok=True)
joblib.dump(model, 'model/risk_model.pkl')

print("✅ Random Forest model trained and saved successfully.")
