"""
Complete command line control for financial.py
Temporary UI until GUI is up and running
"""
from financial import *
import hashlib


"""
Login
"""
username = "test"
# password in sha256 encryption
password = "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8" # password = password

i = 0
while i < 5:
    userIn = input("USERNAME: \t")
    passIn = input("PASSWORD: \t")
    passEnc = hashlib.sha256(str.encode(passIn)).hexdigest()

    if userIn != username or passEnc != password:
        print("\nUSERNAME OR PASSWORD INCORRECT - %d ATTEMPTS REMAINING" % (4-i))
    else:
        print("\nACCESS GRANTED")
        break

    i += 1
    if i == 5:
        print("NUMBER OF TRIES EXCEEDED - PROGRAM WILL NOW TERMINATE")
        for i in range(0, 3):
            text = "Program will exit in"
            sec = 3 - i
            print (text, "(", sec, end =" ) seconds \r")
            time.sleep(1)
        print()
        exit()