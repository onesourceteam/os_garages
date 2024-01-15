<script>
  export let vehicle, index, selected, setSelected;
</script>

<button
  type="button"
  on:click={() => setSelected(index)}
  class="w-[317px] h-[68px] bg-white rounded-[5px] bg-opacity-[0.03] p-[5px] flex-none"
>
  <div
    class="w-full h-full bg-white bg-opacity-5 rounded-[3px] flex items-center justify-between px-[17px]"
  >
    <p class="text-[13px] uppercase font-semibold text-white text-opacity-60">
      {vehicle.name}
    </p>
    <div
      class="h-[23px] aspect-square rounded-full grid place-items-center bg-main bg-opacity-10"
    >
      <div
        style={`opacity: ${selected ? "1" : "0"}`}
        class="bg-main h-[9px] aspect-square rounded-full duration-100"
      />
    </div>
  </div>
</button>
