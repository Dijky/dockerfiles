# Stage 1: Build
FROM alpine:latest AS builder

# Install tools
RUN apk add --no-cache nasm

# Setup workdir
RUN mkdir -p /home/true
WORKDIR /home/true

# Copy source
COPY true.asm .

# Compile
RUN mkdir out
#RUN nasm -f bin -DTRUE_ARCH=x86   -o out/true32 ./true.asm
RUN nasm -f bin -DTRUE_ARCH=amd64 -o out/true64 ./true.asm

# Set exec permission
RUN chmod +x out/*

### ============
# Stage 2: Final image
FROM scratch

# Copy binary
COPY --from=builder /home/true/out/* /
# Execute
CMD ["/true64"]
