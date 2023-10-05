const request = require('supertest');
const AWS = require('aws-sdk');
const app = require('./apiServer'); // Adjust this path to your actual file location.

let server;

// Start the server before tests
beforeAll(() => {
    server = app.listen(3000); // Choose any free port for testing.
});

// Close the server after tests
afterEach(done => {
    server.close(() => {
        setTimeout(done, 500); // Close the server and wait for 500ms before the next test.
    });
});

// Mock AWS DynamoDB
const mockPut = jest.fn();
AWS.DynamoDB.DocumentClient.prototype.put = mockPut;

beforeEach(() => {
    mockPut.mockReset();
});

describe('Express app', () => {
    describe('GET /status', () => {
        it('should return server status', async () => {
            const response = await request(app).get('/status');
            expect(response.statusCode).toBe(200);
            expect(response.text).toBe('Server is running!');
        });
    });

    describe('POST /data', () => {
        it('should require all fields', async () => {
            const response = await request(app).post('/data').send({
                falafel_rating: 5,
                falafel_restaurant: "Falafel King"
                // missing other fields
            });
            expect(response.statusCode).toBe(400);
            expect(response.body).toEqual({ error: 'Missing required fields' });
        });

        it('should insert data into DynamoDB', async () => {
            mockPut.mockImplementation((params, callback) => {
                callback(null, {});
            });

            const data = {
                falafel_rating: 5,
                falafel_restaurant: "Falafel King",
                falafel_time: "12:30",
                falafel_cost: 15
            };

            const response = await request(app).post('/data').send(data);
            expect(response.statusCode).toBe(200);
            expect(response.body).toEqual(data);
        });

        it('should handle DynamoDB errors', async () => {
            mockPut.mockImplementation((params, callback) => {
                callback(new Error("DynamoDB error"), null);
            });

            const data = {
                falafel_rating: 5,
                falafel_restaurant: "Falafel King",
                falafel_time: "12:30",
                falafel_cost: 15
            };

            const response = await request(app).post('/data').send(data);
            expect(response.statusCode).toBe(500);
            expect(response.body).toEqual({ error: 'Failed to insert data into DynamoDB' });
        });
    });
});
