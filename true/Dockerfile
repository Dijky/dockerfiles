# Stage 1: Build
FROM alpine:latest as builder

# Install tools
RUN apk add --no-cache nasm

# Setup workdir
RUN mkdir -p /home/true
WORKDIR /home/true

# Copy source
COPY true.asm .

# Compile
RUN nasm -f bin -o ./true.bin ./true.asm

# Set exec permission
RUN chmod +x ./true.bin

### ============
# Stage 2: Final image
FROM scratch

# Copy binary
COPY --from=builder /home/true/true.bin /true
# Execute
CMD ["/true"]
