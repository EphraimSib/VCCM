import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout
from tensorflow.keras.optimizers import Adam
import numpy as np

# Define risk levels
RISK_LEVELS = ['Safe', 'Medium', 'High', 'Critical']

def create_model(input_dim):
    model = Sequential([
        Dense(64, activation='relu', input_shape=(input_dim,)),
        Dropout(0.3),
        Dense(32, activation='relu'),
        Dropout(0.2),
        Dense(len(RISK_LEVELS), activation='softmax')
    ])
    model.compile(optimizer=Adam(learning_rate=0.001),
                  loss='categorical_crossentropy',
                  metrics=['accuracy'])
    return model

def train_model(model, X_train, y_train, epochs=20, batch_size=32):
    model.fit(X_train, y_train, epochs=epochs, batch_size=batch_size, validation_split=0.2)

def predict_risk(model, transaction_features):
    """
    Predict the risk level of a transaction.
    transaction_features: numpy array of shape (1, input_dim)
    Returns: risk level string
    """
    probabilities = model.predict(transaction_features)
    risk_index = np.argmax(probabilities)
    return RISK_LEVELS[risk_index]

if __name__ == "__main__":
    # Example usage with dummy data
    input_dim = 10  # Number of features
    model = create_model(input_dim)

    # Generate dummy training data
    X_train = np.random.rand(1000, input_dim)
    y_train = tf.keras.utils.to_categorical(np.random.randint(0, len(RISK_LEVELS), 1000), num_classes=len(RISK_LEVELS))

    train_model(model, X_train, y_train)

    # Predict risk for a dummy transaction
    test_transaction = np.random.rand(1, input_dim)
    risk = predict_risk(model, test_transaction)
    print(f"Predicted risk level: {risk}")
