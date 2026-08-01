import pandas as pd
from sklearn.model_selection import cross_val_predict, StratifiedKFold
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
from sklearn.preprocessing import LabelEncoder

# Step 1: Load the dataset
df = pd.read_csv('./balanced_user_behavior_new.csv')  # Replace with your actual filename

# Step 2: Encode the target labels
le = LabelEncoder()
df['risk_level'] = le.fit_transform(df['risk_level'])  # Example mapping: Low=1, Medium=2, High=0

# Step 3: Define features and target
X = df.drop('risk_level', axis=1)
y = df['risk_level']

# Step 4: Initialize classifier and cross-validation strategy
clf = RandomForestClassifier(n_estimators=100, random_state=42)
kfold = StratifiedKFold(n_splits=10, shuffle=True, random_state=42)

# Step 5: Perform cross-validation predictions
y_pred = cross_val_predict(clf, X, y, cv=kfold)

# Step 6: Evaluate results
print("Confusion Matrix:\n", confusion_matrix(y, y_pred))
print("\nClassification Report:\n", classification_report(y, y_pred, target_names=le.classes_))
print("Accuracy Score:", accuracy_score(y, y_pred))
