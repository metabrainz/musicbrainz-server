const regex = /^[1-9][0-9]*$/;

function isPositiveInteger(value) {
  return regex.test(value);
}

export default isPositiveInteger;
