export default async function <T = any>(
  eventName: string,
  payloadData: unknown = {}
): Promise<T> {
  const options = {
    method: "post",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify(payloadData),
  };

  const resourceName = (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : "env-browser";

  const resp = await fetch(`https://${resourceName}/${eventName}`, options);

  return await resp.json();
}
