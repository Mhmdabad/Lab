import mlflow
import mlflow.sklearn

from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score


# Connect to MLflow running in Kubernetes through port-forward
mlflow.set_tracking_uri("http://localhost:5000")

# Create/use an experiment
mlflow.set_experiment("iris-classification")


# Load data
X, y = load_iris(return_X_y=True)

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42
)


# Parameters
max_iter = 200


with mlflow.start_run():

    # Train model
    model = LogisticRegression(max_iter=max_iter)
    model.fit(X_train, y_train)

    # Evaluate
    predictions = model.predict(X_test)
    accuracy = accuracy_score(y_test, predictions)

    # Log metadata -> stored through MLflow in RDS
    mlflow.log_param("max_iter", max_iter)
    mlflow.log_param("test_size", 0.2)

    mlflow.log_metric("accuracy", accuracy)

    # Log model -> artifact stored in S3
    mlflow.sklearn.log_model(
        model,
        name="model"
    )

    print(f"Accuracy: {accuracy}")
    print("Run logged successfully!")