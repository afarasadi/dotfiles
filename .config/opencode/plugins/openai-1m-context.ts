import type { Plugin } from "@opencode-ai/plugin";

const plugin: Plugin = async () => {
  return {
    provider: {
      id: "openai",
      async models(provider, ctx) {
        if (ctx.auth?.type !== "oauth") {
          return provider.models;
        }

        const models = { ...provider.models };
        for (const [modelId, model] of Object.entries(provider.models)) {
          if (!modelId.startsWith("gpt-5.6-")) {
            continue;
          }

          const longModelId = `${modelId}-1m`;

          models[longModelId] = {
            ...model,
            name: `${model.name} (1M context)`,
            limit: {
              context: 1_000_000,
              input: 872_000,
              output: 128_000,
            },
          };
        }

        return models;
      },
    },
  };
};

export default plugin;
