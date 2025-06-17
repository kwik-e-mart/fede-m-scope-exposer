const axios = require('axios');

const apiKey = process.env.DEMO_OPEN_WEATHER_API_KEY;

async function fetchCity(query) {
    try {
        const response = await axios.get(`https://api.openweathermap.org/geo/1.0/direct`, {
            params: {
                q: `${query}`,
                limit: 10,
                appid: apiKey,
            }
        });
        return response.data;
    } catch (error) {
        console.error('Error fetching weather by city:', error);
        return null;
    }
}

async function fetchWeather(lat, lon) {
    try {
        const response = await axios.get(`https://api.openweathermap.org/data/2.5/weather`, {
            params: {
                lat: lat,
                lon: lon,
                lang: 'en',
                units: 'metric',
                appid: apiKey,
            }
        });
        return response.data;
    } catch (error) {
        console.error('Error fetching weather by coordinates:', error);
        return null;
    }
}

module.exports = { fetchCity, fetchWeather };
