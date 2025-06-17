<h2 align="center">
    <a href="https://httpie.io" target="blank_">
        <img height="100" alt="nullplatform" src="https://nullplatform.com/favicon/android-chrome-192x192.png" />
    </a>
    <br>
    <br>
    Technology Template for Node.js
    <br>
</h2>

Welcome to the **Technology Template for Demo** repository! This repository provides an example for building server or serverless applications using Node.js. Whether you're new to nullplatform development or looking to streamline your workflow, this template offer a great starting point.

## Table of Contents

- [Introduction](#introduction)
- [Getting Started](#getting-started)

## Introduction

 This repository aims to provide you with a Node.js-based template that follow best practices for container and serverless development helping you get started quickly and efficiently.

* Serverless architecture allows you to focus on writing code without the need to manage infrastructure
* You can also deploy this application using a Docker image on EC2 instances or K8s clusters

## Getting Started

To get started, follow these steps:

1. **Install Dependencies**: Navigate to the template directory and install the required dependencies.
   ```bash
   npm install
   ```

2. **Development**: Start building your serverless application using the template as a foundation.

    You can run this application locally by executing:
   ```bash
   npm run start
   ```

3. **Link demo services**

   You can link demo services by running:
   ```bash
   API_KEY="<service_management_api_key>" NRN="<application_nrn>" ENVIRONMENT="production" node link-services.js
   ```

4. **Fetch weather data**

   You can fetch weather data by opening this url in your browser:
   ```http request
   <your_scope_domain>/weather?query=<city,state,country>&cache=true
   ```
   for example:
   
   ```http request
   <your_scope_domain>/weather?query=madrid
   ```


---

Enjoy building applications using this Node.js template! If you have any questions or feedback, please open an issue in the repository. Happy coding!
