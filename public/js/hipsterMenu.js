var hipsterAdjectives =
  [ "heritage"
  , "vegan"
  , "antique"
  , "craft"
  , "tradittional"
  , "Brazillian"
  , "fusion"
  , "Japanese"
  , "traditional"
  , "revival"
  , "sauted"
  , "iconic"
  , "luxury"
  , "contemporary"
  , "gin-infused"
  , "handcrafted"
  , "oak-aged"
  , "Mongolian"
  , "Beech twig smoked"
  , "Driftwood-smoked"
  , "salvaged"
  , "instagrammed"
  , "lomographed"
  , "vintage"
  , "overripe"
  , "retro"
  , "authentic"
  , "coal-fired"
  , "twice baked"
  , "semi-cremated"
  , "thrice griddled"
  , "cold-brewed"
  , "delicatessen-fresh"
  , "hand-reared"
  , "umami"
  , "lightly pickled"
  , "fair trade"
  , "artisanal"
  , "street food"
  , "foraged"
  , "home-brewed"
  , "foamed"
  , "sun-blushed"
  ];
var hipsterFoodstuffs =
  [ "avocado"
  , "quinoa"
  , "burger"
  , "steak"
  , "tomato"
  , "potato"
  , "kale"
  , "popcorn"
  , "pulled pork"
  , "tofu"
  , "spirulina"
  , "berries"
  , "superfoods"
  , "stilton"
  , "blackcurrant jam"
  , "marmite"
  , "candy"
  , "candy floss"
  , "blackcurrant jous"
  , "pickled egg"
  , "Strawberry pilsner"
  , "olives"
  , "rapeseed oil"
  , "sherbert"
  , "leaves"
  , "kombucha"
  , "ale"
  , "kimchi"
  , "intestines"
  , "sheeps brains"
  , "pickled onion"
  , "green juice"
  , "goji berry"
  , "matcha tea"
  , "roiboss espresso"
  , "salted caramel"
  , "lamb cheeks"
  , "ocelot's earlobes"
  , "wolf's nipples"
  , "truffle"
  , "truffle oil"
  , "zucchini blossoms"
  , "balsamic vinegar"
  , "horse penis"
  , "duck's eyes"
  ];
var hipsterVessels    =
  [ "on a broken shovel"
  , "on a salvaged plank"
  , "on a chopping board"
  , "on a limited edition 12 inch vinyl record of 80s electropop"
  , "on a casette tape"
  , "on a log"
  , "on a house tile"
  , "on a signed first edition of Jack Kerouac's 'On the Road'"
  , "on an autographed photo of Taylor Swift"
  , "in a rusty enamel bucket"
  , "in a rusty wheelbarrow"
  , "in a suitcase"
  , "in a paper envelope"
  , "on a bed of wheatgrass"
  , "on a wooden board"
  , "in a wheelie bin"
  , "in a packing crate"
  , "wrapped in silk kimono inside a vintage tea chest"
  , "on a hub cap"
  , "in a car tyre"
  , "in a jam jar"
  , "in a mini-wheelbarrow"
  , "in a shoe"
  , "in a plant pot"
  , "in an ashtray"
  , "on an inverted ashtray"
  , "on a ships tiller"
  , "kebabed on bicycle spokes"
  , "in a plastic colander"
  , "thrust into some vintage y-fronts"
  , "in a tiny watering can"
  , "on a gardening trowel"
  , "on a reclaimed carpet tile"
  , "in a broken microwave. Ping!"
  , "on a baking tray, sprinkeld with icing sugar"
  , "in a vintage dog bowl"
  , "in a zinc cat bowl"
  , "in a Japanese high-healed shoe"
  , "in a seedtray"
  , "in an authentic porcelein urinal"
  ];
var hipsterPrepositions =
  [ "with"
  , "accompanied by"
  , "alongside"
  , "paired with"
  , "combined with"
  , "amidst"
  , "co-presented with"
  , "married to"
  , "next to"
  , "in correlation with"
  , "atop"
  , "in bed with"
  , "beneath"
  , "in conjunction with"
  , "conjoined with"
  , "proximal to"
  , "harmonised with"
  ]
var hipsterServingMethods =
  [ "served"
  , "curated"
  , "presented"
  , "displayed"
  , "collated"
  , "aggregated"
  , "delivered"
  , "exhibited"
  , "brought forth"
  , "sited"
  , "propagated"
  , "laid out"
  ]

function curateMeal() {
  var ingredients = knuthShuffle(hipsterFoodstuffs).slice(0,2);
  var adjectives  = knuthShuffle(hipsterAdjectives).slice(0,2);
  return ucfirst(adjectives[0])
       + " "
       + ingredients[0]
       + " "
       + hipsterPrepositions[Math.floor(Math.random() * hipsterPrepositions.length)]
       + " "
       + adjectives[1]
       + " "
       + ingredients[1]
       + " "
       + hipsterServingMethods[Math.floor(Math.random() * hipsterServingMethods.length)]
       + " "
       + hipsterVessels[Math.floor(Math.random() * hipsterVessels.length)]
       + "."
  ;
}

function serveHipster(elt) {
    elt.innerText = curateMeal();
}

// Code for Knuth Shuffle (c) https://github.com/coolaj86
// from: https://github.com/Daplie/knuth-shuffle/blob/master/index.js
// And used under terms of Apache2 license
function knuthShuffle (array) {
  var currentIndex = array.length
    , temporaryValue
    , randomIndex
    ;

  while (0 !== currentIndex) {

    randomIndex = Math.floor(Math.random() * currentIndex);
    currentIndex -= 1;

    temporaryValue = array[currentIndex];
    array[currentIndex] = array[randomIndex];
    array[randomIndex] = temporaryValue;
  }

  return array;
}

function ucfirst(xs) {
    return xs.charAt(0).toUpperCase() + xs.slice(1);
}
