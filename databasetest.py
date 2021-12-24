
import mysql.connector as mysql
db = mysql.connect(
            host = "192.168.1.104",
            database = "financial",
            user = "project",
            password = "trackerPass"
            )

cursor = db.cursor()

query = 'call newIncome(350.00, "rent", "Mom", "2021-12-01", "Housing")'

cursor.execute(query)
db.commit()
cursor.close()