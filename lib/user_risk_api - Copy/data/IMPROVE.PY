import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
from imblearn.over_sampling import SMOTE

# تحميل البيانات
df = pd.read_csv("./balanced_user_behavior.csv")  # تأكد من مسار الملف

# إنشاء ميزة جديدة: متوسط النقاط
df["avg_score"] = df[["bidding_score", "transaction_score", "delivery_score"]].mean(axis=1)

# إعادة تصنيف مستوى الخطر
def redefine_risk(row):
    if row["fraud_reports"] >= 3 or row["avg_score"] < 0.6:
        return "High"
    elif row["avg_score"] >= 0.85 and row["fraud_reports"] == 0:
        return "Low"
    else:
        return "Medium"

df["risk_level"] = df.apply(redefine_risk, axis=1)

# فصل المتغيرات
X = df.drop("risk_level", axis=1)
y = df["risk_level"]

# تحويل الفئات لأرقام
label_map = {"Low": 0, "Medium": 1, "High": 2}
y_num = y.map(label_map)

# تقسيم البيانات بنسبة 70/30
X_train, X_test, y_train, y_test = train_test_split(
    X, y_num, test_size=0.3, stratify=y_num, random_state=42
)

# موازنة بيانات التدريب باستخدام SMOTE
smote = SMOTE(random_state=42)
X_train_resampled, y_train_resampled = smote.fit_resample(X_train, y_train)

# تحجيم البيانات
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train_resampled)
X_test_scaled = scaler.transform(X_test)

# تدريب النموذج باستخدام Random Forest
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train_scaled, y_train_resampled)

# التنبؤ
y_pred = model.predict(X_test_scaled)

# تحويل الأرقام إلى أسماء الفئات
reverse_label_map = {v: k for k, v in label_map.items()}
y_test_named = y_test.map(reverse_label_map)
y_pred_named = pd.Series(y_pred).map(reverse_label_map)

# طباعة النتائج
print("Confusion Matrix:\n", confusion_matrix(y_test_named, y_pred_named, labels=["Low", "Medium", "High"]))
print("\nClassification Report:\n", classification_report(y_test_named, y_pred_named))
print("Accuracy Score:", accuracy_score(y_test_named, y_pred_named))

# عرض بيانات أولية بعد التعديل
print("\nData shape:", df.shape)
# print(df.head())
