const fastify = require('fastify')({ logger: { level: 'info' } });
const fastifyView = require('@fastify/view');
const ejs = require('ejs');
const { fetchCity, fetchWeather } = require('./weather');
const { fetchItem, saveItem } = require('./dynamodb');

fastify.register(fastifyView, {
    engine: { ejs },
});

// Declare a route
fastify.get('/', async (request, reply) => {
    return { hello: 'world' };
});

// Health
fastify.get('/health', async (request, reply) => {
    return { status: 'ok' };
});

// Fetch Weather
fastify.get('/weather', async (request, reply) => {
    const { query, cache } = request.query;
    const data = await getWeatherForSearch(query, cache);
    return reply.view('weather.ejs', data);
});

const getWeatherForSearch = async (query, cache) => {
    const date = new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
    const foundCities = await fetchCity(query);
    if (!foundCities || foundCities.length === 0) {
        return { date, temp: null, city: null, icon: null };
    }
    const { name: city, lat, lon } = foundCities[0];
    if (cache) {
        return fetchItem(city);
    } else {
        const { weather, main: { temp } } = await fetchWeather(lat, lon);
        const icon = weather[0].icon;
        const data = { date, temp, city, icon };
        saveItem(data).catch(error => console.error(`Error saving data into cache: ${error.message}`));
        return data;
    }
}

module.exports = fastify;
