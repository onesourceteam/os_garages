import { isEnvBrowser } from "./misc";

interface DebugEvent<T = any> {
  action: string;
  payload: T;
}

export const debugData = <P>(events: DebugEvent<P>[], timer = 1000): void => {
  if (isEnvBrowser()) {
    for (const event of events) {
      setTimeout(() => {
        window.dispatchEvent(
          new MessageEvent("message", {
            data: {
              action: event.action,
              payload: event.payload,
            },
          })
        );
      }, timer);
    }
  }
};
