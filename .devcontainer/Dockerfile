FROM --platform=linux/amd64 node:lts-bookworm-slim
SHELL ["/bin/bash", "-c"]
RUN apt update && apt install -y curl bash git tar gzip libc++-dev build-essential
RUN curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
ENV PATH="/root/.nargo/bin:$PATH"
RUN noirup
ENTRYPOINT ["nargo"]

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Add Cargo to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

RUN cd /workspaces/base && nargo codgen-verifier --workspace && ./copy_verifiers.sh 

