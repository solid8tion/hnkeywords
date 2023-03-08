FROM public.ecr.aws/p2t7j0q6/lambda-elixir:latest AS compile

ENV LANG C.UTF-8

COPY . /app

RUN cd /app && \
  mix local.hex --force && \
  mix local.rebar --force && \
  mix clean && \
  mix deps.get --only prod && \
  MIX_ENV=prod mix release --path /release && \
  chmod -R a=rX /release

FROM public.ecr.aws/lambda/provided:al2.2023.02.28.13 AS package

ENV LANG C.UTF-8

COPY --from=compile /release .
COPY --chmod=755 priv/bootstrap ${LAMBDA_RUNTIME_DIR}/bootstrap

CMD [ "Elixir.Hnkeywords.lambda_handler" ]