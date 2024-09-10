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
let isInshowcase = false;

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
                vehicleItem.classList.add('bg-zinc-900', 'w-[200px]', 'h-[200px]', 'rounded-sm', 'border-2', 'border-zinc-800', 'p-4', 'transition-transform', 'transform', 'hover:scale-105');
    
                const vehicleImage = document.createElement('img');
                if (vehicle.img) {
                    vehicleImage.src = vehicle.img;
                    vehicleImage.style.maxWidth = '100%';
                    vehicleImage.style.maxHeight = '56%';
                    vehicleImage.style.margin = 'auto';
                    vehicleImage.style.objectFit = 'contain';
                }
                else {
                    vehicleImage.src = `https://raw.githubusercontent.com/matthias18771/v-vehicle-images/main/images/${key}.png`;
                };
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
                    const carName = vehicleItem.querySelector('h1').textContent;
                    document.getElementById('carName').textContent = `${carName}`;
                    document.getElementById('price').textContent = `Price: $${formattedNumberDE}`;
                    document.getElementById('carSpeed').textContent = `Speed: ${vehicle.speed}`;
            
                    // Add slide animation
                    if (selectedCar === vehicleItem) {
                        selectedCar = null;
                    } else {
                        selectedCar = vehicleItem;
                    }

                    fetch(`https://${GetParentResourceName()}/Showcase`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({ vehicle: key})
                    });
                    $("#vehicleshop").hide("slide");
                    setTimeout(() => {
                        $("#InfoBox").show("slide");
                        isInshowcase = true;
                    }, 200); // Wait for 1 second before playing the animation
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

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        $("#InfoBox").hide("slide");
        $("#vehicleshop").hide("slide");
        selectedCar = null;
        // Send NUI event to client Lua
        fetch(`https://${GetParentResourceName()}/Showcase`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({type: 'closefull'})
        });
    }
    if (isInshowcase) {
        if (event.key === 'Enter') {
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
            isInshowcase = false;
        } else if (event.key === 'Backspace') {
            $("#InfoBox").hide("slide");
            $("#vehicleshop").show("slide");
            selectedCar = null;
            fetch(`https://${GetParentResourceName()}/Showcase`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({type: 'close'})
            });
            isInshowcase = false;
        }
    }
});

$("#InfoBox").hide();
$("#vehicleshop").hide();