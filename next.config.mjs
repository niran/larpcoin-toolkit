/** @type {import('next').NextConfig} */
const nextConfig = {
  exclude: ["evm"],
  webpack: (config) => {
    config.externals.push("pino-pretty", "lokijs", "encoding");
    return config;
  },
};

export default nextConfig;
