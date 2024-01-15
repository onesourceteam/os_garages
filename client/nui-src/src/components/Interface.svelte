<script>
  import { onMount } from "svelte";
  import Footer from "./Footer.svelte";
  import Header from "./Header.svelte";
  import VehicleList from "./VehicleList.svelte";
  import fetch from "../lib/fetch";
  import { vehicles } from "../store/vehicles";
  $: title = "GARAGEM";
  $: selected = -1;
  onMount(() => {
    fetch("getCurrentGarage")
    .then((resp) => {
      if (resp.vehicles.length > -1) {
          title = resp.title;
          vehicles.set(resp.vehicles);
        }
      })
      .catch((err) => {
        console.error(err);
      });
  });
  const setSelected = (index) => {
    if (index !== selected) {
      selected = index;
    } else {
      selected = -1;
    }
  };
</script>

<main
  class="animate-fade w-screen h-screen bg-gradient-to-r from-black from-[-20%] to-transparent to-[50%] flex flex-col justify-center pl-[36px] gap-[26px]"
>
  <Header {title} />
  <VehicleList {setSelected} {selected} />
  <Footer {selected} />
</main>
