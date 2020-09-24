function lowerCaseF(a) {
    a.value = a.value.toLowerCase();
    a.value = a.value.replace(/@.*/, "");
}
