from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score

import mlflow

# Load data
X, y = load_iris(return_X_y=True)

X_train, X_test, y_train, y_test = train_test_split(
    X, y,
    test_size=0.2,
    random_state=42
)

# Parameters
max_iter = 300

# Start MLflow run
with mlflow.start_run():

    model = LogisticRegression(max_iter=max_iter)

    # Train
    model.fit(X_train, y_train)

    # Evaluate
    predictions = model.predict(X_test)
    accuracy = accuracy_score(y_test, predictions)

    # Save information to MLflow
    mlflow.log_param("max_iter", max_iter)
    mlflow.log_metric("accuracy", accuracy)

    print("Accuracy:", accuracy)