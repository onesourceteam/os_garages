<script lang="ts">
  import Interface from "./components/Interface.svelte";
  import "./style/global.css";
  import VisibilityProvider from "./providers/VisibilityProvider.svelte";
  import { debugData } from "./lib/debugPost";

  debugData([
    {
      action: "ui:visibility",
      payload: true,
    },
  ]);
</script>

<VisibilityProvider>
  <Interface />
</VisibilityProvider>
