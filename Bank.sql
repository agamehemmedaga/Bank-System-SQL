git add hesabat.sqlCREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR (100) NOT NULL ,
    balance NUMERIC (15 , 2) NOT NULL DEFAULT 0.00 CHECK ( balance >=0 )
);

CREATE TABLE transfers (
    id SERIAL PRIMARY KEY,
    sender_account_id INT REFERENCES accounts (id) ON DELETE CASCADE,
    receiver_account_id INT REFERENCES accounts(id) ON DELETE  CASCADE,
    amount NUMERIC (15 , 2) NOT NULL CHECK ( amount > 0 ),
    transfers_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transaction_history(
    id SERIAL PRIMARY KEY ,
    account_id INT REFERENCES accounts (id) ON DELETE CASCADE,
    operation_type VARCHAR (10) CHECK ( operation_type IN ('DEPOSIT' , 'WITHDRAW') ),
    amount NUMERIC (15 ,2)NOT NULL ,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO accounts ( customer_name, balance) VALUES ('Anar Aliyev', 500.00);
INSERT INTO accounts ( customer_name, balance) VALUES ('Zeyneb Mahmudova', 100.00);


CREATE OR REPLACE PROCEDURE  make_transfer(
    p_sender_id INT,
    p_receiver_id INT,
    p_amount NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE accounts
    SET balance = balance - p_amount
    WHERE  id = p_sender_id;

    UPDATE accounts
    SET balance = balance + p_amount
    WHERE id = p_receiver_id;

    INSERT INTO transfers( sender_account_id , receiver_account_id , amount)
    VALUES(p_sender_id , p_receiver_id , p_amount);

    INSERT INTO transaction_history (account_id , operation_type, amount)
    VALUES (p_sender_id , 'WITHDRAW' , p_amount);

    INSERT INTO transaction_history (account_id , operation_type , amount)
    VALUES (p_receiver_id, 'DEPOSIT' , p_amount);

    COMMIT;
    RAISE NOTICE 'Tranzaksiya ugurla tamamlandi COMMIT olundu. ';

    EXCEPTION
    WHEN OTHERS THEN

    ROLLBACK;
    RAISE NOTICE ' Xeta bas verdi  ! Sistem ROLLBACK olundu. Xeta mesaji: %',SQLERRM;

    END;
    $$;

CALL make_transfer (1,2,150.00);
SELECT *FROM accounts;
SELECT *FROM transfers;
SELECT *FROM transaction_history;

CALL make_transfer (1,2,400.00);
SELECT *FROM accounts;

UPDATE accounts SET balance = 350.00 WHERE id = 1;
UPDATE accounts SET balance = 250.00 WHERE id = 2;







