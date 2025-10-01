from flask import Flask
import redis

app = Flask(__name__)
#connect to redis
client = redis.Redis(host='redis', port=6379)

# Route 1 - Welcome message
@app.route('/')
def welcome():
    return "Welcome to my App!"

# Route 1 - displays visitor count and increments
@app.route('/count')
def count():
    count = client.incr('visitor_count')
    return f'You are Visitor number: {count}'


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)