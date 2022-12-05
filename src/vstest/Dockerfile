FROM mcr.microsoft.com/dotnet/core/sdk:3.1-bionic AS builder
COPY . .
RUN dotnet publish "Yeha.Api/Yeha.Api.csproj" --configuration Release --output /app/publish

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-bionic AS runtime
WORKDIR /app
EXPOSE 80
COPY --from=builder /app/publish .
ENTRYPOINT ["dotnet", "Yeha.Api.dll"]
