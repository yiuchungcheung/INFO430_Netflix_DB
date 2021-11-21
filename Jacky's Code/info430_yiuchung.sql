
-- populating tblcustomer_type
BEGIN TRAN populate_tblCustomer_Type

INSERT INTO tblCUSTOMER_TYPE(CustomerTypeName, CustomerTypeDesc)
VALUES('Basic', '$8.99/month, you can watch on 1 screen at the same time, you can have 1 phone/tablet to have downloads on, Unlimited movies, TV shows and mobile games, Watch on your laptop, TV, phone and tablet')

INSERT INTO tblCUSTOMER_TYPE(CustomerTypeName, CustomerTypeDesc)
VALUES('Standard', '$13.99/month, you can watch on 2 screens at the same time, you can have 2 phones/tablets to have downloads on, Unlimited movies, TV shows and mobile games, Watch on your laptop, TV, phone and tablet, HD available')

INSERT INTO tblCUSTOMER_TYPE(CustomerTypeName, CustomerTypeDesc)
VALUES('Premium', '$17.99/month, you can watch on 4 screens at the same time, you can have 4 phones/tablets to have downloads on, Unlimited movies, TV shows and mobile games, Watch on your laptop, TV, phone and tablet, HD available, Ultra HD available')


COMMIT TRAN populate_tblCustomer_Type

SELECT * FROM tblCUSTOMER_TYPE


SELECT * FROM tblCUSTOMER

