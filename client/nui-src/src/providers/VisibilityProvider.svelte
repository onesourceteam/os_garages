<script lang="ts">
  import { onMount } from "svelte";
  import fetch from "../lib/fetch";
  import eventListener from "../lib/useNuiEvent";
  import { Router, Route, navigate } from "svelte-routing";

  eventListener<boolean>("ui:visibility", (visible: boolean) => {
    navigate("/ui");
  });

  onMount(() => {
    const keyHandler = (e: KeyboardEvent) => {
      if (location.pathname.includes("/ui") && ["Escape"].includes(e.code)) {
        fetch("removeFocus");
        navigate("/");
      }
    };
    window.addEventListener("keydown", keyHandler);
    return () => window.removeEventListener("keydown", keyHandler);
  });
</script>

<Router>
  <Route path="/*" />
  <Route path="/ui/*">
    <slot />
  </Route>
</Router>
