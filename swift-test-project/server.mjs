import express from 'express';
import graphqlHTTP from 'express-graphql';
import pkg from 'graphql';
const { buildSchema } = pkg;
import { readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

const schema = buildSchema(readFileSync(join(__dirname, 'schema.graphql')).toString());

const org = { id: 'a', name: 'org' };

const rootValue = {
  organizations: () => [org],
  outerAndInnerNullableOrganizations: () => null,
  outerAndInnerNullableOrganizations2: () => [null, org],
  outerNullableOrganizations: () => null,
  outerNullableOrganizations2: () => [org],
  innerNullableOrganizations: [null, org],
  nullableOrganization: (_id) => null,
  organization: (_id) => org,
};

var app = express();
app.use('/graphql', graphqlHTTP({ schema, rootValue }));
app.listen(4000);
