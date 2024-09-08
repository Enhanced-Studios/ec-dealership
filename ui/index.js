document.getElementById('searchInput').addEventListener('input', function() {
    const searchValue = this.value.toLowerCase();
    const carElements = document.querySelectorAll('#cars > div');

    carElements.forEach(car => {
        const carName = car.querySelector('h1').textContent.toLowerCase();
        if (carName.includes(searchValue)) {
            car.style.display = '';
        } else {
            car.style.display = 'none';
        }
    });
});

function showCategory(category) {
    const carElements = document.querySelectorAll('#cars > div');

    carElements.forEach(car => {
        const carCategory = car.getAttribute('data-category');

        if (carCategory === category || category === 'all') {
            car.style.display = '';
        } else {
            car.style.display = 'none';
        }
    });
}

let selectedCar = null;

// Listen for FiveM Lua function call
window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.show === true) {
        $("#vehicleshop").show("slide");
        // Clear existing vehicle list
        document.getElementById('cars').innerHTML = '';

        // Create vehicle list for each vehicle in data.vehicles
        for (const [key, vehicle] of Object.entries(data.vehicles)) {
            if (data.class[vehicle.class]) {
                const vehicleItem = document.createElement('div');
                vehicleItem.classList.add('bg-zinc-900', 'w-[200px]', 'h-[200px]', 'rounded-lg', 'border-2', 'border-zinc-800', 'p-4', 'transition-transform', 'transform', 'hover:scale-105');
    
                const vehicleImage = document.createElement('img');
                vehicleImage.src = `https://raw.githubusercontent.com/matthias18771/v-vehicle-images/main/images/${key}.png`;
                vehicleItem.appendChild(vehicleImage);
    
                const vehicleName = document.createElement('h1');
                vehicleName.classList.add('text-white', 'text-center', 'text-2xl', 'mt-6', 'font-semibold');
                vehicleName.textContent = vehicle.label;
                vehicleItem.appendChild(vehicleName);
    
                const vehiclePrice = document.createElement('h1');
                vehiclePrice.classList.add('text-purple-600', 'text-center', 'text-lg', 'font-semibold');
                const formattedNumberDE = new Intl.NumberFormat("en-US").format(vehicle.price);
                vehiclePrice.textContent = `$${formattedNumberDE}`;
                vehicleItem.appendChild(vehiclePrice);
    
                vehicleItem.setAttribute('data-category', vehicle.class);
                vehicleItem.setAttribute('data-key', key);
    
                document.getElementById('cars').appendChild(vehicleItem);
    
                vehicleItem.addEventListener('click', function() {
                    const buyButton = document.getElementById('buyButton');
                    const carName = vehicleItem.querySelector('h1').textContent;
                    const carImage = vehicleItem.querySelector('img').src;
            
                    document.getElementById('carImage').src = carImage;
                    document.getElementById('carName').textContent = `${carName}`;
                    document.getElementById('carSpeed').textContent = `Speed: ${vehicle.speed}`;
                    buyButton.textContent = `Buy ${carName}`;
            
                    // Add slide animation
                    if (selectedCar === vehicleItem) {
                        $("#InfoBox").hide("slide");
                        selectedCar = null;
                    } else {
                        $("#InfoBox").show("slide");
                        selectedCar = vehicleItem;
                    }
                });
            }
          }
          for (const [key, value] of Object.entries(data.class)) {
            if (value === false) {
                $(`[data-buttonclass='${key}']`).hide();
            }
        }
    } else {
        $("#vehicleshop").hide("slide");
    }
});

const buyButton = document.getElementById('buyButton');
buyButton.addEventListener('click', function() {
    const vehicle = selectedCar.getAttribute('data-key');
    // Send NUI event to client Lua
    fetch(`https://${GetParentResourceName()}/buy`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ vehicle: vehicle})
    });
    $("#InfoBox").hide("slide");
    $("#vehicleshop").hide("slide");
    selectedCar = null;
    // Send NUI event to client Lua
    fetch(`https://${GetParentResourceName()}/close`);
});


document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        $("#InfoBox").hide("slide");
        $("#vehicleshop").hide("slide");
        selectedCar = null;
        // Send NUI event to client Lua
        fetch(`https://${GetParentResourceName()}/close`);
    }
});

$("#InfoBox").hide();
$("#vehicleshop").hide();