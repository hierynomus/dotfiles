# Kubernetes helpers. Ported from the old dotmac zplug/kube.zsh + zshrc.

alias k=kubectl
alias kctx='kubie ctx'   # if kubie is installed
alias kns='kubie ns'
alias k8s-show-ns=" kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n"

klogs() {
  kubectl logs -l app.kubernetes.io/name="$1"
}

kube_dns() {
  kubectl get pods -n kube-system -oname | grep coredns | xargs kubectl delete -n kube-system
}

# Dynamically build KUBECONFIG from every file in ~/.kube/*.yaml, re-evaluated
# before each prompt so a new context file just needs to land in ~/.kube/.
if [[ -d "$HOME/.kube" ]]; then
  autoload -Uz add-zsh-hook
  _set_kubeconfig() {
    local files=("$HOME"/.kube/*.yaml(N))
    (( $#files )) && export KUBECONFIG="${(j.:.)files}"
  }
  add-zsh-hook precmd _set_kubeconfig
fi

# Ctrl-K: fuzzy-pick a kube context with fzf and switch to it.
if which fzf-tmux > /dev/null 2>&1 || which fzf > /dev/null 2>&1; then
  kcctx() {
    local context
    local finder="fzf"
    which fzf-tmux > /dev/null 2>&1 && finder="fzf-tmux -p 60%,40%"
    context=$(kubectl config get-contexts --output=name | sort | eval "$finder --tac --prompt='K8s Context: '")
    if [[ -n "$context" ]]; then
      kubectl config use-context "$context"
      echo "Switched to context: $context"
    else
      echo "No context selected."
    fi
  }
  kcctx_widget() {
    zle -I
    kcctx
    zle reset-prompt
  }
  zle -N kcctx_widget
  bindkey '^k' kcctx_widget
fi
