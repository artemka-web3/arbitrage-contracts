var scalePrice;
var pantheonPrice;
var usdcPrice;



function fetchPantheonPriceData() {
  return fetch('https://api.geckoterminal.com/api/v2/networks/base/tokens/0x993cd9c0512cfe335bc7eF0534236Ba760ea7526')
    .then(function (response) {
      if (response.ok) {
        return response.json();
      } else {
        throw new Error('Ошибка при выполнении запроса');
      }
    })
    .then(function (data) {
      return parseFloat(data.data.attributes.price_usd)
    })
    .catch(function (error) {
      console.error(error);
    });
}


function fetchScalePriceData() {
  return fetch('https://coins.llama.fi/prices/current/base:0x54016a4848a38f257B6E96331F7404073Fd9c32C')
    .then(function (response) {
      if (response.ok) {
        return response.json();
      } else {
        throw new Error('Ошибка при выполнении запроса');
      }
    })
    .then(function (data) {
      return data.coins['base:0x54016a4848a38f257B6E96331F7404073Fd9c32C'].price;
    })
    .catch(function (error) {
      console.error(error);
    });
}

function fetchUSDCPriceData() {
    return fetch('https://coins.llama.fi/prices/current/base:0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913')
      .then(function (response) {
        if (response.ok) {
          return response.json(); 
        } else {
          throw new Error('Ошибка при выполнении запроса');
        }
      })
      .then(function (data) {
        return data.coins['base:0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913'].price;
      })
      .catch(function (error) {
        console.error(error);
      });
}

async function getUSDC_SCALE_ratio() {
  try {
    const scaleData = await fetchScalePriceData();
    scalePrice = scaleData;
    const usdcData = await fetchUSDCPriceData();
    usdcPrice = usdcData;
    let pantheonPrice = await fetchPantheonPriceData();

    let scale_usdc_ration = usdcPrice / scalePrice


    let scale_for_one_pantheon = (pantheonPrice / scalePrice) / scale_usdc_ration
    let usdc_for_one_pantheon = pantheonPrice / usdcPrice


    console.log("scalePrice: ", scalePrice)
    console.log("USDC Price: ", usdcPrice)
    console.log("PANTHEON Price: ", pantheonPrice)
    console.log("scale usdc ratio (Scales for USDC): ", scale_usdc_ration)


    console.log("scale_for_one_pantheon ", scale_for_one_pantheon)
    console.log("usdc_for_one_pantheon ", usdc_for_one_pantheon)



    


  } catch (error) {
    console.error(error);
  }
}

getUSDC_SCALE_ratio();
