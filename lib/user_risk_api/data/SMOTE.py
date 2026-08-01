import pandas as pd
from sklearn.preprocessing import LabelEncoder
from imblearn.over_sampling import SMOTE

# 1. تحميل الملف
df = pd.read_csv("./balanced_user_behavior_new.csv")

# 2. إزالة التكرارات
df = df.drop_duplicates()

# 3. فصل الميزات عن الهدف
X = df.drop("risk_level", axis=1)
y = df["risk_level"]

# 4. ترميز الفئة الهدف إن كانت غير رقمية
if y.dtype == 'object':
    le = LabelEncoder()
    y_encoded = le.fit_transform(y)
else:
    y_encoded = y

# 5. تطبيق SMOTE
smote = SMOTE(random_state=42)
X_resampled, y_resampled = smote.fit_resample(X, y_encoded)

# 6. إنشاء DataFrame جديد
df_resampled = pd.DataFrame(X_resampled, columns=X.columns)

# إعادة الكود الأصلي للفئة الهدف
if y.dtype == 'object':
    df_resampled['risk_level'] = le.inverse_transform(y_resampled)
else:
    df_resampled['risk_level'] = y_resampled

# 7. حفظ الملف الجديد
df_resampled.to_csv("balanced_user_behavior_new.csv", index=False)

print("✅  SMOTE: balanced_user_behavior_new.csv")
