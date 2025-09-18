export OPENAI_API_KEY=secret_abcdefg
export OPENAI_API_BASE="http://localhost:8000/v1"

RAY_memory_usage_threshold=0.99 RAY_num_cpus=1 OPENAI_API_BASE="http://127.0.0.1:8000/v1" OPENAI_API_KEY="sk-local" python token_benchmark_ray.py   --model "Qwen/Qwen3-0.6B"   --mean-input-tokens 128   --stddev-input-tokens 32   --mean-output-tokens 64   --stddev-output-tokens 16   --max-num-completed-requests 50   --timeout 300   --num-concurrent-requests 1   --results-dir "result_outputs/tiny_safe"   --llm-api openai   --additional-sampling-params '{}'