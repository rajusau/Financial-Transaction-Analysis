import mysql.connector

# Correct the connection details
connection = mysql.connector.connect(
    host="localhost",       # Corrected host, without the port number
    port=3306,              # Specify the port number separately
    user="root",            # Replace with your MySQL username
    password="1234",        # Replace with your MySQL password
    database="fintech_pro"  # Replace with your database name
)


# Create a cursor object using the connection
cursor = connection.cursor()

# Execute an SQL query
cursor.execute("SELECT * FROM transactions")  # Replace with your table name

# Fetch the results of the executed query
results = cursor.fetchall()

# Print the results
for row in results:
    print(row)

# Close the cursor and connection
cursor.close()
connection.close()
