import assert from "node:assert/strict";
import test from "node:test";

import plugin from "../plugins/openai-1m-context.ts";

test("adds 1M variants to OAuth-backed GPT 5.6 models", async () => {
  const provider = {
    models: {
      "gpt-5.6-luna": {
        name: "GPT-5.6 Luna",
        limit: {
          context: 600_000,
          output: 128_000,
        },
      },
      "gpt-5.5": {
        name: "GPT-5.5",
      },
    },
  };

  const hooks = await plugin();
  const models = await hooks.provider?.models?.(provider, {
    auth: { type: "oauth" },
  });

  assert.ok(models);
  assert.deepEqual(models["gpt-5.6-luna-1m"], {
    ...provider.models["gpt-5.6-luna"],
    name: "GPT-5.6 Luna (1M context)",
    limit: {
      context: 1_000_000,
      input: 872_000,
      output: 128_000,
    },
  });
  assert.equal(models["gpt-5.5-1m"], undefined);
});

test("leaves models unchanged for non-OAuth authentication", async () => {
  const provider = {
    models: {
      "gpt-5.6-luna": {
        name: "GPT-5.6 Luna",
      },
    },
  };

  const hooks = await plugin();
  const models = await hooks.provider?.models?.(provider, {
    auth: { type: "api" },
  });

  assert.equal(models, provider.models);
});
