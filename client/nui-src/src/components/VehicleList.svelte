<script>
  import Vehicle from "./Vehicle.svelte";
  import { vehicles } from "../store/vehicles";
  export let setSelected, selected;
</script>

<section class="w-[332px] h-[492px] flex flex-col gap-[12px]">
  <div class="flex items-center gap-[10px] w-[317px] min-h-[18px]">
    <p class="leading-none text-[14px] text-white font-light opacity-35">
      Seus veículos ({$vehicles.length})
    </p>
    <div class="w-full h-[2px] bg-white opacity-10 flex-1" />
  </div>
  <ul class="flex flex-col gap-[12px] overflow-y-auto">
    {#each $vehicles as vehicle, index (index)}
      <Vehicle {vehicle} {setSelected} {index} selected={selected === index} />
    {/each}
  </ul>
</section>

<style>
  ::-webkit-scrollbar {
    width: 5px;
    background: rgba(255, 255, 255, 0.05);
    border-radius: 1000px;
  }
  ::-webkit-scrollbar-thumb {
    width: 5px;
    background: #f33;
    border-radius: 1000px;
  }
</style>
