import pandas as pd
from sklearn.tree import DecisionTreeClassifier
import joblib
import os
import mysql.connector

# الاتصال بقاعدة البيانات
conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='',
    database='final'
)

# query = "SELECT * FROM user_risk_data"
query = "SELECT * FROM dataset"

df = pd.read_sql_query(query, conn)


print("📊 القيم الأصلية في risk_level:", df['risk_level'].unique())

df['risk_level'] = df['risk_level'].astype(str).str.strip().str.capitalize()

print("✅ بعد التنظيف:", df['risk_level'].unique())


valid_levels = ['Low', 'Medium', 'High']
df = df[df['risk_level'].isin(valid_levels)]

X = df[['account_authenticity', 'bidding_score', 'transaction_score', 'delivery_score', 'fraud_reports']]
y = df['risk_level'].map({'Low': 0, 'Medium': 1, 'High': 2})

print(f"🔢 عدد السجلات بعد التنظيف: {len(df)}")

model = DecisionTreeClassifier()
model.fit(X, y)

os.makedirs('model', exist_ok=True)

joblib.dump(model, 'model/risk_model.pkl')

print("✅ النموذج تم تدريبه وحفظه بنجاح.")
