<script>
  import { vehicles } from "./../store/vehicles.ts";
  import fetch from "../lib/fetch";
  export let selected;
  const storeVehicle = () => fetch("storeVehicle");
  const spawnVehicle = () => {
    console.log(selected);
    if (selected >= 0 && typeof selected === "number") {
      fetch("spawnVehicle", {
        vehicle: $vehicles[selected],
      });
    }
  };
</script>

<footer class="flex flex-col w-[317px] gap-[15px]">
  <button
    type="button"
    on:click={() => spawnVehicle()}
    class="h-[50px] w-full rounded-[5px] uppercase text-[12px] font-semibold border border-solid border-main text-main bg-main bg-opacity-10 hover:bg-opacity-100 hover:text-white"
    >retirar</button
  >
  <button
    type="button"
    on:click={() => storeVehicle()}
    class="h-[50px] w-full rounded-[5px] uppercase text-[12px] font-semibold border border-solid border-white border-opacity-5 bg-white bg-opacity-[0.08] hover:bg-opacity-[0.2] text-white text-opacity-35 hover:text-opacity-100"
    >guardar próximo</button
  >
</footer>
