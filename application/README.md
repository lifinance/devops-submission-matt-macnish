# Falafel Reviews API

The Falafel Reviews API is a Node.js-based application that receives data and posts it to DynamoDB.

## Setup & Running the API Locally:

### 1. Clone the Repository:
```bash
git clone [your-repository-url]
cd [repository-name]/application
```

### 2. Installing Dependencies:

   - Using `package.json`:
```bash
npm install
```
   - Manual installation without `package.json`:

   - Dependencies:
```bash
npm install aws-sdk@^2.1468.0 body-parser@^1.20.2 express@^4.18.2 prom-client@^14.2.0
```
   - Dev Dependencies:
```bash
npm install --save-dev @sinonjs/referee-sinon@^11.0.0 @types/jest@^29.5.5 @types/supertest@^2.0.14 jest@^29.7.0 supertest@^6.3.3
```

### 3. Running DynamoDB Locally:

   Download and unzip the [DynamoDB Local](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html) for your specific OS.

   - Start DynamoDB Local:
```bash
java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb
```
   - Update the `apiServer.js` (or the filename with your API logic) to connect to your local DynamoDB instance:
```javascript
AWS.config.update({
  region: "eu-west-1",
  endpoint: "http://localhost:8000"
});
```

### 4. Starting the API Server:
```bash
node apiServer.js
```
## Docker Container and AWS ECR:

The Falafel Reviews API uses a containerization approach via Docker to ensure consistent deployment. Whenever there's an update pushed to the main branch of the application, the provided GitHub Action workflow automatically creates a new Docker image based on the `Dockerfile` in the `./application` directory. This image is then tagged with the latest commit SHA and timestamp, ensuring a unique and traceable identifier for each image. Once built, the image is pushed to the Amazon Elastic Container Registry (ECR) under the repository named `falafelapp`.

### Automated Docker Build and Push with GitHub Actions:

1. **Checkout Code**: The GitHub Action workflow starts by checking out the latest code from the main branch.

2. **Configure AWS Credentials**: AWS credentials, stored securely as GitHub secrets, are configured. These are essential for authenticating and pushing the Docker image to ECR.

3. **Login to Amazon ECR**: The workflow logs into Amazon ECR, ensuring subsequent steps can push the Docker image.

4. **Set Unique Tag**: For traceability and versioning, each Docker image is tagged with both the commit SHA of the latest change and a timestamp.

5. **Build, Tag, and Push Image**: The Docker image is built, then tagged, and finally pushed to the specified ECR repository.

This automated process ensures that the Docker image in ECR always reflects the latest version of the application in the main branch.

### Using the Docker Container Locally:

1. Ensure you have Docker installed on your machine.
2. Navigate to the `./application` directory.
3. Build the Docker image:
```bash
docker build -t falafelapp .
```
4. Run the container locally:
```bash
docker run -p 3000:3000 falafelapp
```

This local setup allows for testing and development in an environment identical to the deployed version.

### Note:
Ensure you have appropriate permissions and credentials set up when working with AWS services, including ECR. Misconfigurations or missing permissions can lead to errors during the Docker push process.

## Testing:

### Local Setup and Running Tests:

1. Navigate to the `./application` directory and run tests:
```bash
npm test
```

### Test Implementation:

The tests utilize the `supertest` library to simulate HTTP requests to our Express server and validate responses. AWS DynamoDB interactions are mocked using Jest's mock functions, so tests do not interact with the real database.

### Automated Testing with GitHub Actions:

Every push or pull request modifying content within the `./application` directory triggers the GitHub Actions workflow, which runs the tests and reports results directly in your GitHub repository.

## Additional Notes:

- Make sure to merge changes from your repository's main branch consistently to avoid potential merge conflicts or outdated testing scenarios.
- When adding new features or changes to the API, ensure corresponding tests are written or updated.
