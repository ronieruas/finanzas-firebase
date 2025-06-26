/** @type {import('next').NextConfig} */
const nextConfig = {
  /* config options here */
  typescript: {
    ignoreBuildErrors: true,
  },
  eslint: {
    ignoreDuringBuilds: true,
  },
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'placehold.co',
        port: '',
        pathname: '/**',
      },
    ],
  },
  // Habilita a saída 'standalone' para otimização de imagem Docker.
  // Isso cria uma pasta .next/standalone com apenas os arquivos necessários.
  output: 'standalone',
};

module.exports = nextConfig;
