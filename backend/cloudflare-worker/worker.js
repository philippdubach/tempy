/**
 * Cloudflare Worker to proxy Shelly Cloud API requests
 * This keeps your API credentials secure on the server side
 * Also stores and serves historical temperature data
 */

const CORS_HEADERS = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET'
};

export default {
  async fetch(request, env) {
    if (request.method !== 'GET') {
      return new Response('Method not allowed', { status: 405, headers: CORS_HEADERS });
    }

    const url = new URL(request.url);
    const path = url.pathname;

    if (path === '/history' || path === '/history/') {
      return await getHistoryResponse(env);
    }

    if (path === '/' || path === '') {
      return await getCurrentTemperature(env);
    }

    return new Response('Not found', { status: 404, headers: CORS_HEADERS });
  }
};

async function getCurrentTemperature(env) {
  try {
    const shellyServer = env.SHELLY_SERVER_URL || 'https://shelly-211-eu.shelly.cloud';
    
    const insideUrl = new URL(`${shellyServer}/device/status`);
    insideUrl.searchParams.set('id', env.SHELLY_INSIDE_DEVICE_ID);
    insideUrl.searchParams.set('auth_key', env.SHELLY_AUTH_KEY);

    const outsideUrl = new URL(`${shellyServer}/device/status`);
    outsideUrl.searchParams.set('id', env.SHELLY_OUTSIDE_DEVICE_ID);
    outsideUrl.searchParams.set('auth_key', env.SHELLY_AUTH_KEY);

    const insideResponse = await fetch(insideUrl.toString());
    const insideData = await insideResponse.json();
    
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    const outsideResponse = await fetch(outsideUrl.toString());
    const outsideData = await outsideResponse.json();

    if (!insideData.isok) {
      console.error('Inside device error:', insideData);
      if (insideData.error === 'TOO_MANY_REQUESTS' || insideData.errors?.TOO_MANY_REQUESTS) {
        throw new Error('API rate limit exceeded. Please wait before trying again.');
      }
      throw new Error(`Inside device: ${JSON.stringify(insideData.errors || insideData)}`);
    }
    
    if (!outsideData.isok) {
      console.error('Outside device error:', outsideData);
      if (outsideData.error === 'TOO_MANY_REQUESTS' || outsideData.errors?.TOO_MANY_REQUESTS) {
        throw new Error('API rate limit exceeded. Please wait before trying again.');
      }
      throw new Error(`Outside device: ${JSON.stringify(outsideData.errors || outsideData)}`);
    }

    const insideTempObj = insideData?.data?.device_status?.['temperature:0'];
    const outsideTempObj = outsideData?.data?.device_status?.['temperature:0'];
    
    const insideTemp = insideTempObj?.tC;
    const outsideTemp = outsideTempObj?.tC;

    if (insideTemp === undefined || outsideTemp === undefined) {
      console.error('Inside data structure:', JSON.stringify(insideData, null, 2));
      console.error('Outside data structure:', JSON.stringify(outsideData, null, 2));
      throw new Error('Temperature not found in API response. Check console logs for structure.');
    }

    await storeHistory(env, insideTemp, outsideTemp);

    return new Response(
      JSON.stringify({
        inside: insideTemp,
        outside: outsideTemp
      }),
      {
        headers: {
          ...CORS_HEADERS,
          'Cache-Control': 'public, max-age=120'
        }
      }
    );
  } catch (error) {
    console.error('Error:', error);
    return new Response(
      JSON.stringify({ 
        error: 'Failed to fetch temperature data',
        details: error.message 
      }),
      {
        status: 500,
        headers: CORS_HEADERS
      }
    );
  }
}

async function storeHistory(env, inside, outside) {
  try {
    if (env.TEMPERATURE_HISTORY) {
      const history = await getHistory(env);
      const entry = {
        timestamp: Date.now(),
        inside: inside,
        outside: outside
      };
      
      history.push(entry);
      
      const cutoff = Date.now() - (24 * 60 * 60 * 1000);
      const filtered = history.filter(e => e.timestamp > cutoff);
      
      await env.TEMPERATURE_HISTORY.put('data', JSON.stringify(filtered));
    }
  } catch (error) {
    console.error('Error storing history:', error);
  }
}

async function getHistoryResponse(env) {
  try {
    const history = await getHistory(env);
    return new Response(
      JSON.stringify(history),
      {
        headers: {
          ...CORS_HEADERS,
          'Cache-Control': 'public, max-age=60'
        }
      }
    );
  } catch (error) {
    console.error('Error getting history:', error);
    return new Response(
      JSON.stringify({ error: 'Failed to fetch history', details: error.message }),
      {
        status: 500,
        headers: CORS_HEADERS
      }
    );
  }
}

async function getHistory(env) {
  try {
    if (env.TEMPERATURE_HISTORY) {
      const data = await env.TEMPERATURE_HISTORY.get('data');
      if (data) {
        return JSON.parse(data);
      }
    }
    return [];
  } catch (error) {
    console.error('Error getting history:', error);
    return [];
  }
}
