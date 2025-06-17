const axios = require('axios');
const apiKey = process.env.API_KEY;
const nrn = process.env.NRN;
const environment = process.env.ENVIRONMENT;

(async () => {

    if (!apiKey) {
        console.error('Missing API_KEY in env');
        process.exit(0);
    }

    if (!nrn) {
        console.error('Missing NRN in env');
        process.exit(0);
    }

    if (!environment) {
        console.error('Missing ENVIRONMENT in env');
        process.exit(0);
    }

    const apiKeyData = { api_key: apiKey };

    const tokenCallResult = await axios.post('https://api.nullplatform.com/token', apiKeyData);
    const { access_token: token } = tokenCallResult.data;

    const dynamoDbData = {
        name: capitalizeString(environment),
        specification_id: '6b14b24d-ba3c-4fca-951c-472b318e278e',
        service_id: '6dfa6994-3769-4948-a8a3-15d768b51ace',
        entity_nrn: nrn,
        dimensions: { environment }
    };

    const weatherServiceData = {
        name: capitalizeString(environment),
        specification_id: '620df502-9a52-4dc8-b211-59764aea918a',
        service_id: '4c2d2444-d4d3-4b95-820f-bca1987fb1ce',
        entity_nrn: nrn,
        dimensions: { environment }
    };

    const config = {
        headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
        }
    };

    await axios.post('https://api.nullplatform.com/link', dynamoDbData, config);
    await axios.post('https://api.nullplatform.com/link', weatherServiceData, config);
})();

const capitalizeString = (str) => {
    if (!str) return '';
    return str.charAt(0).toUpperCase() + str.slice(1);
}
