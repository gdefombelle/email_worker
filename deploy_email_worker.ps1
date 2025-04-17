# === deploy_email_worker.ps1 ===

$remoteServer = "gabriel@195.201.9.184"
$imageName = "gdefombelle/email_worker:latest"
$containerName = "email_worker"

Write-Host "🔨  Build local de l'image Docker (no-cache)..."
docker build --no-cache -t $imageName .

Write-Host "📦  Push vers Docker Hub..."
docker push $imageName

Write-Host "🔁  Connexion SSH et déploiement..."

$remoteCommand = "docker stop $containerName || true && docker rm $containerName || true && docker image rm $imageName || true && docker pull $imageName && docker run -d --name $containerName --network pytune_network --env-file /home/gabriel/pytune.env -v /var/log/pytune:/var/log/pytune --restart always $imageName"

ssh $remoteServer $remoteCommand

Write-Host "✅  Déploiement terminé pour $containerName !"
