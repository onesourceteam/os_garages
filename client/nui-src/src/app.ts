import Index from "./Index.svelte";

const app = new Index({
  target: document.getElementById("app") as HTMLElement,
});

export default app;
