
DROP TABLE IF EXISTS transaction_history;
DROP TABLE IF EXISTS transfers;
DROP TABLE IF EXISTS accounts;

CREATE TABLE accounts (
                          id            SERIAL PRIMARY KEY,
                          customer_name VARCHAR(100) NOT NULL,
                          balance       NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0)
);

CREATE TABLE transfers (
                           id                  SERIAL PRIMARY KEY,
                           sender_account_id   INT REFERENCES accounts (id) ON DELETE CASCADE,
                           receiver_account_id INT REFERENCES accounts (id) ON DELETE CASCADE,
                           amount              NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
                           transfers_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transaction_history (
                                     id             SERIAL PRIMARY KEY,
                                     account_id     INT REFERENCES accounts (id) ON DELETE CASCADE,
                                     operation_type VARCHAR(10) CHECK (operation_type IN ('DEPOSIT', 'WITHDRAW')),
                                     amount         NUMERIC(15, 2) NOT NULL,
                                     created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO accounts (customer_name, balance) VALUES ('Anar Aliyev', 500.00);
INSERT INTO accounts (customer_name, balance) VALUES ('Zeyneb Mahmudova', 100.00);

CREATE OR REPLACE PROCEDURE make_transfer(
    p_sender_id   INT,
    p_receiver_id INT,
    p_amount      NUMERIC
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_balance NUMERIC;
BEGIN
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Transfer amount must be positive';
    END IF;

    IF p_sender_id = p_receiver_id THEN
        RAISE EXCEPTION 'Sender and receiver must be different accounts';
    END IF;

    SELECT balance INTO v_balance
    FROM accounts
    WHERE id = p_sender_id
        FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sender account % not found', p_sender_id;
    END IF;

    IF v_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient funds: balance %, requested %', v_balance, p_amount;
    END IF;

    UPDATE accounts SET balance = balance + p_amount WHERE id = p_receiver_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Receiver account % not found', p_receiver_id;
    END IF;

    UPDATE accounts SET balance = balance - p_amount WHERE id = p_sender_id;

    INSERT INTO transfers (sender_account_id, receiver_account_id, amount)
    VALUES (p_sender_id, p_receiver_id, p_amount);

    INSERT INTO transaction_history (account_id, operation_type, amount)
    VALUES (p_sender_id, 'WITHDRAW', p_amount);

    INSERT INTO transaction_history (account_id, operation_type, amount)
    VALUES (p_receiver_id, 'DEPOSIT', p_amount);

    RAISE NOTICE 'Transfer of % from account % to account % completed', p_amount, p_sender_id, p_receiver_id;
END;
$$;

CALL make_transfer(1, 2, 150.00);
SELECT * FROM accounts ORDER BY id;
SELECT * FROM transfers;
SELECT * FROM transaction_history ORDER BY id;

CALL make_transfer(1, 2, 400.00);
SELECT * FROM accounts ORDER BY id;