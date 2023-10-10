const express = require('express');
const bodyParser = require('body-parser');
const AWS = require('aws-sdk');
const prom = require('prom-client');

// ---- DynamoDB Initialization ----
const DocumentClient = new AWS.DynamoDB.DocumentClient();

// ---- Express Setup ----
const app = express();
app.use(bodyParser.json());

// Prometheus Metrics Setup ----
const register = new prom.Registry();
const httpRequestsTotal = new prom.Counter({
    name: 'http_requests_total',
    help: 'Total number of HTTP requests',
    labelNames: ['method', 'route', 'code'],
    registers: [register],
});
const httpResponseDurationMs = new prom.Histogram({
    name: 'http_response_duration_ms',
    help: 'Duration of HTTP responses in ms',
    labelNames: ['method', 'route', 'code'],
    registers: [register],
    buckets: [0.10, 5, 15, 50, 100, 200, 300, 400, 500],
});
app.use((req, res, next) => {
    const route = req.path;
    const method = req.method;
    const responseStartTime = Date.now();
    res.on('finish', () => {
        const responseTimeMs = Date.now() - responseStartTime;
        const statusCode = String(res.statusCode);
        httpRequestsTotal.labels(method, route, statusCode).inc();
        httpResponseDurationMs.labels(method, route, statusCode).observe(responseTimeMs);
    });
    next();
});

// Status check endpoint
app.get('/status', (req, res) => {
    res.send('Server is running!');
});

app.get('/data', (req, res) => {
    const { falafel_restaurant } = req.query;
    if (!falafel_restaurant) {
        return res.status(400).json({ error: 'falafel_restaurant query parameter is required' });
    }
    const params = {
        TableName: 'FalafelReviews',
        KeyConditionExpression: 'falafel_restaurant = :restaurantName',
        ExpressionAttributeValues: {
            ':restaurantName': falafel_restaurant
        }
    };
    DocumentClient.query(params, (err, data) => {
        if (err) {
            return res.status(500).json({ error: `Failed to fetch data from DynamoDB: ${err.message}` });
        }
        res.json(data.Items);
    });
});

app.post('/data', (req, res) => {
    const { falafel_rating, falafel_restaurant, falafel_time, falafel_cost } = req.body;
    if (!falafel_rating || !falafel_restaurant || !falafel_time || !falafel_cost) {
        return res.status(400).json({ error: 'Missing required fields' });
    }
    const params = {
        TableName: 'FalafelReviews',
        Item: {
            falafel_restaurant,
            falafel_rating,
            falafel_time,
            falafel_cost
        }
    };
    DocumentClient.put(params, (err, data) => {
        if (err) {
            return res.status(500).json({ error: 'Failed to insert data into DynamoDB' });
        }
        res.json(req.body);
    });
});

// Only start servers when script is run directly
if (require.main === module) {
    // Main API server on port 3000
    const API_PORT = 3000;
    app.listen(API_PORT, () => {
        console.log(`Server API is running on port ${API_PORT}`);
    });

    // Prometheus metrics on port 5050
    const metricsApp = express();
    metricsApp.get('/metrics', async (req, res) => {
        try {
            res.set('Content-Type', register.contentType);
            res.end(await register.metrics());
        } catch (ex) {
            res.status(500).end(ex);
        }
    });
    const METRICS_PORT = 5050;
    metricsApp.listen(METRICS_PORT, '0.0.0.0', () => {
        console.log(`Metrics are exposed on port ${METRICS_PORT}`);
    });
}

// Export the app for testing purposes
module.exports = app;






